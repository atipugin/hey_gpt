# frozen_string_literal: true

class Tokenizer
  include Singleton

  def gpt2
    @gpt2 ||= Tokenizers.from_pretrained('gpt2')
  end
end
