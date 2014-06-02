# = pdf/stamper/rjb.rb -- PDF template stamping.
#
#  Copyright (c) 2007-2009 Jason Yates

require 'rubygems'
require 'rjb'

RjbLoader.before_load do |config|
  # This code changes the JVM classpath, so it has to run BEFORE loading Rjb.
  Dir[File.join(File.dirname(__FILE__), '..', '..', '..', 'ext', '*.jar')].each do |path|
    config.classpath << File::PATH_SEPARATOR + File.expand_path(path)
  end
end

module PDF
  # PDF::Stamper::RJB
  #
  # RJB needs the LD_LIBRARY_PATH and JAVA_HOME environment set for it
  # to work correctly.  For example on my system:
  #
  # export LD_LIBRARY_PATH=/usr/java/jdk1.6.0/jre/lib/i386/:/usr/java/jdk1.6.0/jre/lib/i386/client/:./
  # export JAVA_HOME=/usr/java/jdk1.6.0/
  #
  # Check the RJB documentation if you are having issues with this.
  class Stamper
    def initialize(pdf = nil, options = {})
      # @bytearray    = BYTEARRAY
      # @filestream   = FILESTREAM
      # @acrofields   = ACROFIELDS
      # @pdfreader    = PDFREADER
      # @pdfstamper   = PDFSTAMPER
      # @pdfwriter    = PDFWRITER
      # @image_class  = IMAGE_CLASS
      # @pdf_content_byte_class = PDF_CONTENT_BYTE_CLASS
      # @basefont_class = BASEFONT_CLASS
      # @rectangle = RECTANGLE
      # @gray_color = GRAY_COLOR
    
      template(pdf) if ! pdf.nil?
    end
    
    def is_checkbox(field_type)
      field_type == @acrofields.FIELD_TYPE_CHECKBOX
    end
  
    def template(template)
      reader = PDFREADER.new(template)
      @pagesize = reader.getPageSize(1)
      @numpages = reader.getNumberOfPages()
      @baos = BYTEARRAY.new
      @stamp = PDFSTAMPER.new(reader, @baos)
      @form = @stamp.getAcroFields()
      @black = GRAY_COLOR.new(0.0)
      @canvas_list = { 1 => @stamp.getOverContent(1) }
    end

    # Set a button field defined by key and replaces with an image.
    def image(key, image_path)
      # Idea from here http://itext.ugent.be/library/question.php?id=31 
      # Thanks Bruno for letting me know about it.
      img = IMAGE_CLASS.getInstance(image_path)
      img_field = @form.getFieldPositions(key.to_s)

      
      rect = RECTANGLE.new(img_field[1], img_field[2], img_field[3], img_field[4])
      img.scaleToFit(rect.width, rect.height)
      img.setAbsolutePosition(
        img_field[1] + (rect.width - img.getScaledWidth) / 2,
        img_field[2] + (rect.height - img.getScaledHeight) /2
      )

      cb = @stamp.getOverContent(img_field[0].to_i)
      cb.addImage(img)
    end
    
    # Takes the PDF output and sends as a string.  Basically its sole
    # purpose is to be used with send_data in rails.
    def to_s(flatten_form=true)
      fill(flatten_form)
      @baos.toByteArray
    end
    
    def add_images(images)
      basefont = BASEFONT_CLASS.createFont(@basefont_class.HELVETICA, @basefont_class.CP1252, @basefont_class.NOT_EMBEDDED)
      image_size = []
      half_page_width = @pagesize.width() / 2
      half_page_height = @pagesize.height() / 2
      image_size[0] = half_page_width - 80
      image_size[1] = half_page_height - 80
      pages = (images.length / 4.0).ceil
      pages.times do |index|
        page_number = index + @numpages + 1
        image_index = index * 4
        @stamp.insertPage(page_number, @pagesize)
        over = @stamp.getOverContent(page_number)
        over.setFontAndSize(basefont, 12.0)
        4.times do |n|
          if pdf_image = images[image_index + n]
            if image_path = pdf_image[0]
              img = IMAGE_CLASS.getInstance(image_path)
              img.scaleToFit(image_size[0] + 30, (image_size[1]))
              img_x_offset = (half_page_width - image_size[0]) / 2
              img_y_offset = (half_page_height - img.getScaledHeight()) / 2
              case n
              when 0
                img.setAbsolutePosition(img_x_offset, (half_page_height + img_y_offset))
              when 1
                img.setAbsolutePosition((half_page_width + (img_x_offset - 30)), (half_page_height + img_y_offset))
              when 2
                img.setAbsolutePosition(img_x_offset, img_y_offset)
              when 3
                img.setAbsolutePosition((half_page_width + (img_x_offset - 30)), img_y_offset)
              end
              over.addImage(img)
            end
            if image_label = pdf_image[1]
              over.beginText()
              over.showTextAligned(PDF_CONTENT_BYTE_CLASS.ALIGN_CENTER, image_label, (img.getAbsoluteX() + ((image_size[0] + 30) / 2)), (img.getAbsoluteY() - 15), 0)
              over.endText()
            end
          end
        end
      end
      @stamp.setFullCompression()
    end
    
    def add_image_on_page(page, x, y, url)
      over = @stamp.getOverContent(page)
      img = IMAGE_CLASS.getInstance(url)
      img.setAbsolutePosition(x,y)
      img.scaleToFit(200,70)
      over.addImage(img)
    end
  end
end
