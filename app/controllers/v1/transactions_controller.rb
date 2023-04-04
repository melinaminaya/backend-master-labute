# frozen_string_literal: true

module V1
  class TransactionsController < BaseController
    before_action :set_service, only: %w[create charge]
    before_action :set_transaction, only: %w[show update]
    skip_before_action :authenticate_member!, only: %w[notification]

    def index
      authorize Transaction
      search = Transaction.search(params[:search])
      transactions = search.result
      serializer = TransactionSerializer.new(transactions)

      render json: serializer.serialize_with_pagination(params[:page]), status: :ok
    end

    def show
      authorize @transaction
      serializer = TransactionSerializer.new(@transaction)
      render json: serializer.serialize, status: :ok
    end

    def create
      authorize Transaction

      pay

      @transaction = Transaction.new(transaction_data)
      @transaction.save!
      serializer = TransactionSerializer.new(@transaction)
      render json: serializer.serialize, status: :created
    rescue ActiveRecord::RecordInvalid
      render json: { errors: @transaction.errors.full_messages }, status: :bad_request
    end

    def charge
      authorize Transaction

      pay_charge

      @transaction = Transaction.new(transaction_data)
      @transaction.save!
      serializer = TransactionSerializer.new(@transaction)
      render json: serializer.serialize, status: :created
    rescue ActiveRecord::RecordInvalid
      render json: { errors: @transaction.errors.full_messages }, status: :bad_request
    end

    def update
      authorize @transaction
      @transaction.update!(permitted_params)
      head :no_content
    end

    def notification
      if params[:event] == 'ORDER.NOT_PAID'
        handle_rejected_payment
      elsif params[:event] == 'ORDER.PAID'
        handle_approved_payment
      end

      render nothing: true, status: :ok
    end

    private

    def transaction_data
      {
        service_id: @service.id,
        order_status: @order.status,
        payment_status: @payment.status,
        payment_id: @payment.id,
        order_id: @order.id
      }
    end

    def pay
      create_api
      set_up_notification_channel if Rails.env.production?
      customer = create_or_get_customer
      @order = create_order
      @payment = create_payment
    end

    def pay_charge
      create_api
      set_up_notification_channel if Rails.env.production?
      @order = create_charge_order
      @payment = create_payment
    end

    def set_up_notification_channel
      @wirecard_api.notifications.create(
        events: ['ORDER.PAID'],
        target: 'https://api.labute.com.br/v1/transactions/notification',
        media: 'WEBHOOK'
      )
    end

    def create_api
      auth = Moip2::Auth::Basic.new(ENV['WIRECARD_TOKEN'], ENV['WIRECARD_SECRET'])
      client = Moip2::Client.new(Rails.env.production? ? :production : :sandbox, auth)
      # client = Moip2::Client.new(:production, auth) # For production tests on dev environments only
      @wirecard_api = Moip2::Api.new(client)
    end

    def create_customer
      customer = @wirecard_api.customer.create(
        ownId: @client.id,
        fullname: @client.name,
        email: @client.email,
        birthDate: birthdate.strftime('%F'),
        taxDocument: {
          type: 'CPF',
          number: @client.cpf_number
        },
        phone: {
          countryCode: '55',
          areaCode: @client.area_code,
          number: @client.phone_number
        }
      )

      @client.update(wirecard_id: customer.id)
      customer
    end

    def create_or_get_customer
      @client.wirecard_id.present? ?
        @wirecard_api.customer.show(@client.wirecard_id) :
        create_customer
    rescue Moip2::NotFoundError
      create_customer
    end

    def create_order
      @wirecard_api.order.create(
        own_id: @service.id,
        amount: {
          currency: 'BRL'
        },
        items: [
          {
            product: @service.title,
            quantity: 1,
            detail: @service.description,
            price: price
          }
        ],
        customer: {
          ownId: 12390124391234890,
          fullname: params[:holder][:name],
          email: params[:holder][:email],
          birthDate: birthdate.strftime('%F'),
          taxDocument: {
            type: 'CPF',
            number: params[:holder][:cpf]
          },
          phone: {
            countryCode: '55',
            areaCode: area_code,
            number: phone_number
          },
          shippingAddress: {
            city: address[:city],
            district: address[:district],
            street: address[:street],
            streetNumber: address[:streetNumber],
            zipCode: address[:zipCode],
            state: address[:state],
            country: address[:country],
            complement: address[:complement]
          }
        }
      )
    end

    def create_charge_order
      @wirecard_api.order.create(
        own_id: @service.id,
        amount: {
          currency: 'BRL'
        },
        items: [
          {
            product: @service.title,
            quantity: 1,
            detail: @service.description,
            price: charge_price
          }
        ],
        customer: {
          ownId: @client.id,
          fullname: params[:holder][:name],
          email: params[:holder][:email],
          birthDate: birthdate.strftime('%F'),
          taxDocument: {
            type: 'CPF',
            number: params[:holder][:cpf]
          },
          phone: {
            countryCode: '55',
            areaCode: area_code,
            number: phone_number
          },
          shippingAddress: {
            city: address[:city],
            district: address[:district],
            street: address[:street],
            streetNumber: address[:streetNumber],
            zipCode: address[:zipCode],
            state: address[:state],
            country: address[:country],
            complement: address[:complement]
          }
        }
      )
    end

    def create_payment
      @wirecard_api.payment.create(@order.id,
                                   installment_count: params[:installments],
                                   funding_instrument: {
                                     method: 'CREDIT_CARD',
                                     credit_card: {
                                       hash: params[:card_hash],
                                       holder: {
                                         fullname: params[:holder][:name],
                                         birthdate: birthdate.strftime('%F'),
                                         tax_document: {
                                           type: 'CPF',
                                           number: params[:holder][:cpf]
                                         },
                                         billingAddress: {
                                           city: address[:city],
                                           district: address[:district],
                                           street: address[:street],
                                           streetNumber: address[:streetNumber],
                                           zipCode: address[:zipCode],
                                           state: address[:state],
                                           country: address[:country],
                                           complement: address[:complement]
                                         }
                                       }
                                     }
                                   })
    end

    def address
      params[:holder][:address]
    end

    def area_code
      "#{params[:holder][:phone][1]}#{params[:holder][:phone][2]}"
    end

    def phone_number
      params[:holder][:phone].split(' ').second.delete('-')
    end

    def price
      base_price = @service.accepted_proposal.price * 1.15
      discount = @service.cupon_usage.present? && @service.cupon_usage.cupon.percentage
      price = discount ? (base_price * (1 - (discount / 100))) : base_price
      (price * 100).round
    end

    def charge_price
      charge = @service.charges.last
      base_price = charge['price'] * 1.15
      (base_price * 100).round
    end

    def birthdate
      params[:holder][:birthdate].gsub(/\s+/, '').to_date
    end

    def set_service
      @service = Service.find(params[:service_id])
      @client = @service.client
    rescue ActiveRecord::RecordNotFound
      head :not_found
    end

    def permitted_params
      params.permit
    end

    def set_transaction
      @transaction = Transaction.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      head :not_found
    end

    def approve_payment
      if transaction.order_status == 'PAID' || transaction.payment_status == 'AUTHORIZED' ||
         transaction.payment_status == 'PRE_AUTHORIZED'
        transaction.service.update!(status: Service::IN_PROGRESS)
        send_approved_payment_notification
      end
    end

    def handle_rejected_payment
      @service = Service.find(params[:resource][:order][:ownId])
      send_rejected_payment_email
    end

    def handle_approved_payment
      @service = Service.find(params[:resource][:order][:ownId])
      @service.status = Service::IN_PROGRESS
      @service.save!
      send_approved_payment_email
      send_approved_payment_notification
    end

    def send_rejected_payment_email
      ClientMailer.payment_rejected(@service.id).deliver_later
    end

    def send_approved_payment_email
      ClientMailer.payment_accepted(@service.id).deliver_later
    end

    def send_approved_payment_notification
      return if @service.notified_approved_payment
      @service.update!(notified_approved_payment: true)

      notification_text = {
        title: 'Pagamento aprovado!',
        body: "Seu pagamento para o serviço #{@service.title} foi aprovado"
      }
      notification_data = { type: 'service', service_id: @service.id }
      id = @service.client.registration_id
      Notifier::ClientJob.perform_later(notification_text, notification_data, id) if id.present?
    end

    alias pundit_user current_member
  end
end
