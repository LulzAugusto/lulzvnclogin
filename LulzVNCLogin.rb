#encoding: utf-8

require 'win32ole'
require 'win32/registry'
require 'gibberish'

class VNC_Login
  
  $cipher = Gibberish::AES.new("Your_key_here")
  $Enviroment = 'SOFTWARE\Lulz VNC Login'
  
  def initialize
    begin
      Win32::Registry::HKEY_CURRENT_USER.open($Enviroment, Win32::Registry::KEY_READ) {|reg| @first_use = reg['FIRST_USE']}
    rescue
      Win32::Registry::HKEY_CURRENT_USER.create "software\\Lulz VNC Login"
      Win32::Registry::HKEY_CURRENT_USER.open($Enviroment, Win32::Registry::KEY_WRITE) {|reg| reg['FIRST_USE'] = '1'}
      Win32::Registry::HKEY_CURRENT_USER.open($Enviroment, Win32::Registry::KEY_READ) {|reg| @first_use = reg['FIRST_USE']}
    end
    
    if @first_use == '1'
      self.first_use
      self.do_login
    else
      self.do_login
    end
  end
  
  def first_use
    puts ''
    puts 'ATENCAO >> Certifique-se de que o VNC Viewer esta aberto na etapa de preenchimento de LOGIN e SENHA!'
    puts ''
    puts 'Esse e seu primeiro uso e o programa precisa de algumas informacoes. Da segunda vez em diante, todo o processo sera automatico.'
    puts ''
    puts 'Entre com seu usuario do dominio SI. Ex: joao.silva'
    user = gets.chomp
    puts ''
    puts 'Entre com a sua senha. Por favor, cheque-a para que nao ocorram erros.'
    password = gets.chomp

    encrypted_pwd = $cipher.enc(password)

    Win32::Registry::HKEY_CURRENT_USER.open($Enviroment, Win32::Registry::KEY_WRITE) do |reg|
      reg['FIRST_USE'] = '0'
      reg['USER'] = user
      reg['PWD'] = encrypted_pwd
    end
  end

  def do_login
    Win32::Registry::HKEY_CURRENT_USER.open($Enviroment, Win32::Registry::KEY_READ) do |reg|
      @user = reg['USER']
      @password = $cipher.dec(reg['PWD'])
    end

    wsh = WIN32OLE.new('Wscript.Shell')

    if wsh.AppActivate('Ultr@VNC Authentication')
      sleep(1)
      wsh.SendKeys(@user + '{TAB}')
      sleep(1)
      wsh.Sendkeys(@password + '{TAB}')
      sleep(1)
      wsh.Sendkeys('{ENTER}')
    else
      puts "Nenhum VNC aberto foi encontrado! Pressione qualquer tecla para finalizar."
      gets
    end
  end
end

a = VNC_Login.new