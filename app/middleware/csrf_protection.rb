# модуль для Faye c проверкой CSRF токена
class CsrfProtection
  def incoming(message, request, callback)
    session_token = request.session['_csrf_token']
    # вытаскиваем закодированный токе и удаляем его
    # чтобы его не увидели другие клиенты подписанные на канал
    message_token = message['ext'] && message['ext'].delete('csrfToken')

    unless valid_token?(session_token, message_token)
      message['error'] = '401::Access denied'
    end

    callback.call(message)
  end

  private

  def valid_token?(session_token, message_token)
    # декодируем токены
    masked_token = Base64.strict_decode64(message_token)
    real_token = Base64.strict_decode64(session_token)

    one_time_pad = masked_token[0...32]
    encrypted_csrf_token = masked_token[32..-1]
    # XOR  дешифровка
    csrf_token = xor_byte_string(one_time_pad, encrypted_csrf_token)

    ActiveSupport::SecurityUtils.secure_compare(csrf_token, real_token)
  rescue
    false
  end

  def xor_byte_string(s1, s2)
    s1.bytes.zip(s2.bytes).map { |(c1,c2)| c1 ^ c2 }.pack('c*')
  end
end
