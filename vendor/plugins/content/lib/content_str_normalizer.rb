class ContentStrNormalizer
  # Utility method that retursn an ASCIIfied, downcased, and sanitized    string.
  # It relies on the Unicode Hacks plugin by means of String#chars. We    assume
  # $KCODE is 'u' in environment.rb. By now we support a wide range of    latin
  # accented letters, based on the Unicode Character Palette bundled in   Macs.
  def self.normalize(str)
    n = str.chars.downcase.strip.to_s
    n.gsub!(/[àáâãäåāă]/u,    'a')
    n.gsub!(/æ/u,            'ae')
    n.gsub!(/[ďđ]/u,          'd')
    n.gsub!(/[çćčĉċ]/u,       'c')
    n.gsub!(/[èéêëēęěĕė]/u,   'e')
    n.gsub!(/ƒ/u,             'f')
    n.gsub!(/[ĝğġģ]/u,        'g')
    n.gsub!(/[ĥħ]/,           'h')
    n.gsub!(/[ììíîïīĩĭ]/u,    'i')
    n.gsub!(/[įıĳĵ]/u,        'j')
    n.gsub!(/[ķĸ]/u,          'k')
    n.gsub!(/[łľĺļŀ]/u,       'l')
    n.gsub!(/[ñńňņŉŋ]/u,      'n')
    n.gsub!(/[òóôõöøōőŏŏ]/u,  'o')
    n.gsub!(/œ/u,            'oe')
    n.gsub!(/ą/u,             'q')
    n.gsub!(/[ŕřŗ]/u,         'r')
    n.gsub!(/[śšşŝș]/u,       's')
    n.gsub!(/[ťţŧț]/u,        't')
    n.gsub!(/[ùúûüūůűŭũų]/u,  'u')
    n.gsub!(/ŵ/u,             'w')
    n.gsub!(/[ýÿŷ]/u,         'y')
    n.gsub!(/[žżź]/u,         'z')
    n.gsub!(/\s+/,            '-')
    n.gsub!(/[^\/\sa-z0-9_-]/,   '')
    n.downcase
  end
  
end