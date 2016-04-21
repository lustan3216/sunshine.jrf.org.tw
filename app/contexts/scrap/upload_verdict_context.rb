class Scrap::UploadVerdictContext < BaseContext
  before_perform  :bulid_tempfile
  before_perform  :assign_value
  after_perform   :remove_tempfile

  def initialize(content)
    @content = content
  end

  def perform(verdict)
    @verdict = verdict
    run_callbacks :perform do
      add_error("upload file failed") unless @verdict.save
      true
    end
  end

  private

  def bulid_tempfile
    @file = Tempfile.new("verdict", "#{Rails.root.to_s}/tmp/")
    @file.write(@content)
    @file.rewind
    @file.close
  end

  def assign_value
    @verdict.assign_attributes(file: File.open(@file.path))
  end

  def remove_tempfile
    @file.unlink
  end
end
