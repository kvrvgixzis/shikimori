class BbCodes::Tags::ListTag
  include Singleton

  BBCODE_LIST_REGEXP = %r{
    \[list\] \n?
      (?<ul> .*?)
    \[/list\] \n?
  }mix

  BBCODE_LIST_ITEM_REGEXP = %r{
    \[\*\]
    (?<li>
      (?: (?! \[\* | \[/list\] | \n\n). )+
    )
    (?<brs> \n\n )?
  }mix

  UL_START = "<ul class='b-list'>"
  UL_END = '</ul>'

  def format text
    format_bb_list_items(
      format_bb_lists(text)
    )
  end

private

  def format_bb_lists text
    text.gsub BBCODE_LIST_REGEXP do
      items = $LAST_MATCH_INFO[:ul].gsub(BBCODE_LIST_ITEM_REGEXP) do
        "<li>#{$LAST_MATCH_INFO[:li]}</li>"
      end

      "#{UL_START}#{items}#{UL_END}"
    end
  end

  def format_bb_list_items text
    text.gsub(BBCODE_LIST_ITEM_REGEXP) do
      "#{UL_START}<li>#{$LAST_MATCH_INFO[:li]}</li>#{UL_END}" +
        ($LAST_MATCH_INFO[:brs] ? "\n" : '')
    end
  end
end
