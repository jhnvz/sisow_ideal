module SisowIdeal
  class SisowException < Exception
    attr_accessor :errorcode
    attr_accessor :message

    def initialize(errorcode, message)
      self.errorcode = errorcode
      self.message   = message
    end
  end
end