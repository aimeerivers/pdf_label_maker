module PdfLabelMaker
  
  require 'pdf/writer'
  include PDF



  def self.cell_x(col, options)
    options[:left_margin] + (col * options[:label_width]) + (col * options[:gap_between_labels_x]) + options[:label_padding_x]
  end

  def self.cell_y(row, options)
    options[:bottom_margin] + (((options[:labels_per_page] / options[:columns]) - row) * options[:label_height]) - options[:label_padding_y]
  end

  def self.add_label(row, col, contact, pdf, options)
    if contact
      contact.label_lines.each_with_index do |line, idx|
        label_text_width = options[:label_width] - (2 * options[:label_padding_x])
        pdf.add_text_wrap(cell_x(col, options), cell_y(row, options) - (idx * options[:line_height]), label_text_width, line, options[:font_size])
      end
    end
  end


  
  def self.avery_labels(contacts, code='L7162', options={})
    options[:paper_size] ||= 'A4'
    options[:font] ||= 'Helvetica'
    
    set_layout_options(code, options)
    
    pdf = PDF::Writer.new(:paper => options[:paper_size])
    pdf.select_font(options[:font])

    pages = contacts.length / options[:labels_per_page]
    pages += 1 if (contacts.length % options[:labels_per_page]) > 0
    
    0.upto(pages - 1) do |page|
      start = page * options[:labels_per_page]
      addresses_for_page = contacts[start..(start + options[:labels_per_page])]
    
      0.upto((options[:labels_per_page] / options[:columns]) - 1) do |row|
        0.upto(options[:columns] - 1) do |column|
          add_label(row, column, addresses_for_page[(row * options[:columns]) + column], pdf, options)
        end
      end
    
      pdf.new_page unless page + 1 == pages
    end
    pdf
  end
  
  def self.set_layout_options(code, options)
    case code
    when 'L7162' then
      options[:columns] ||= 2
      options[:labels_per_page] ||= 16
      options[:left_margin] ||= Writer.mm2pts 5
      options[:bottom_margin] ||= Writer.mm2pts 12
      options[:label_width] ||= Writer.mm2pts 99.1
      options[:label_height] ||= Writer.mm2pts 33.9
      options[:label_padding_x] ||= Writer.mm2pts 15
      options[:label_padding_y] ||= Writer.mm2pts 3
      options[:gap_between_labels_x] ||= Writer.mm2pts 0
      options[:font_size] ||= 10
      options[:line_height] ||= 11
    when 'J8651' then
      options[:columns] ||= 5
      options[:labels_per_page] ||= 65
      options[:left_margin] ||= Writer.mm2pts 4
      options[:bottom_margin] ||= Writer.mm2pts 10
      options[:label_width] ||= Writer.mm2pts 38.1
      options[:label_height] ||= Writer.mm2pts 21.2
      options[:label_padding_x] ||= Writer.mm2pts 1
      options[:label_padding_y] ||= Writer.mm2pts 1
      options[:gap_between_labels_x] ||= Writer.mm2pts 3
      options[:font_size] ||= 6
      options[:line_height] ||= 7
    when 'Zweckform4737' then
      options[:columns] ||= 3
      options[:labels_per_page] ||= 27
      options[:left_margin] ||= Writer.mm2pts 7.2
      options[:bottom_margin] ||= Writer.mm2pts 15.1
      options[:label_width] ||= Writer.mm2pts 63.5
      options[:label_height] ||= Writer.mm2pts 29.6
      options[:label_padding_x] ||= Writer.mm2pts 10
      options[:label_padding_y] ||= Writer.mm2pts 4.5
      options[:gap_between_labels_x] ||= Writer.mm2pts 2.5
      options[:font_size] ||= 9
      options[:line_height] ||= 10
    end
  end
  
end
