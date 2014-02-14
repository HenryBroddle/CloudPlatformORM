require 'gmail'

module MailLink
  class Mailbox
    attr_accessor :username, :password

    def initialize(username, password)
      @username = username
      @password = password
    end
    
    def each_unread_message(&block)
      gmail = ""
      emails = []

      3.attempts do
        gmail = Gmail.connect!(username, password)
        emails = gmail.inbox.find(:unread)
      end

      emails.map { |email| email.message }.each do |gmail_message|
        message = build_message(gmail_message)
        yield message
      end
    end

    private
    
    def build_message(gmail_message)
      message = MailLink::Message.new
      message.sent = ""
      message.received = ""
      message.subject = ""
      message.text_body = ""
      message.to_recipients = ""
      message.from = ""
      message.cc_recipients = ""
      message.html_body = ""
      message.sender = ""

      date = gmail_message.date.to_s
      year = date.slice(0..3)
      month = date.slice(5, 2)
      day = date.slice(8, 2)
      hour = date.slice(11, 2)
      minute = date.slice(14, 2)
      message.sent = (month + "-" + day + "-" + year + " " + hour + ":" + minute).to_s
      message.received = message.sent

      message.subject = gmail_message.subject if gmail_message.subject


      if (gmail_message.text_part)
        Rails.logger.info "TEXT PART: #{gmail_message.text_part.decoded}"
        text = gmail_message.text_part.decoded
        Rails.logger.info "HEADER: #{gmail_message.text_part.header}"
        txt_headers = gmail_message.text_part.header
      else
        Rails.logger.info "BODY: #{gmail_message.body.decoded}"
        text = gmail_message.body.decoded
        Rails.logger.info "HEADER: #{gmail_message.header}"
        txt_headers = gmail_message.header
      end

      if text
        message.text_body = text

        if txt_headers
          Rails.logger.info txt_headers
          headers = Hash[txt_headers.to_s.split("\r\n").map { |x| x.split("=").map { |y| y.lstrip.rstrip } }]
          Rails.logger.info headers

          if headers.has_key?("charset") && headers["charset"] != "windows-1252" && headers["charset"] != "us-ascii"
            message.text_body = message.text_body.force_encoding(headers["charset"].gsub(";", "")).encode("UTF-8")
          end
        end
      end

      message.to_recipients = gmail_message.to.join(",") if gmail_message.to
      message.from = gmail_message.from.join(",") if gmail_message.from
      message.cc_recipients = gmail_message.cc.join(",") if gmail_message.cc

      html = gmail_message.html_part
      if html
        html_body = gmail_message.html_part.body.to_s
        if (html.header)
          headers = Hash[html.header.to_s.split("\r\n").map { |x| x.split("=").map { |y| y.lstrip.rstrip } }]
          if headers.has_key?("charset") && headers["charset"] != "windows-1252" && headers["charset"] != "us-ascii"
            message.html_body = html_body.force_encoding(headers["charset"]).encode("UTF-8")
          end
        end
      end

      message.sender = gmail_message.sender
      message.attachments = gmail_message.attachments
      message
    end
  end
end