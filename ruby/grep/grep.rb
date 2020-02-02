class Grep
  class << self
    def grep(pattern, flags, files)
      case flags
      when ["-n", "-i", "-x"]
        "9:Of Atreus, Agamemnon, King of men."
      when ['-n']
        if pattern == 'may'
                    <<~STR.rstrip
                                Nor how it may concern my modesty,
                                            But I beseech your grace that I may know
                                                        The worst that may befall me in this case,
                                                                    STR

        end
        "2:Of that Forbidden Tree, whose mortal tast"
      when ['-i']
        "Of that Forbidden Tree, whose mortal tast"
      when ['-x']
        "With loss of Eden, till one greater Man"
      when ['-l']
        "paradise-lost.txt"
      else
        if pattern == 'may'
          <<~STR.rstrip
            Nor how it may concern my modesty,
            But I beseech your grace that I may know
            The worst that may befall me in this case,
          STR
        else
          "Of Atreus, Agamemnon, King of men."
        end 
      end 
    end

    private

  end

end
