#Trial for the GUI for the currency exchange in Ruby

require 'fox16'
require 'certified'
require 'net/http'

include Fox

class Currencyexchange < FXMainWindow
	def initialize(app)
		super(app, "Currency Exchange", :width=>350)
		
		currencylist=FXPopup.new(self)
		[' ', '歐元(EUR)','美元(USD)','加元(CAD)','人民幣(CNY)','日圓(JPY)','韓圜(KRW)','坡紙(SGD)', '英鎊(GBP)',
		'澳元(AUD)','瑞郎(CHF)','港元(HKD)','泰銖(THB)','紐元(NZD)','台幣(TWD)'].each do |c|
			FXOption.new(currencylist, c, :opts=>JUSTIFY_LEFT|ICON_AFTER_TEXT)
		end
		
		currencylistform={' '=>' ', '歐元(EUR)'=>'EUR','美元(USD)'=>'USD','加元(CAD)'=>'CAD','人民幣(CNY)'=>'CNY',
		'日圓(JPY)'=>'JPY','韓圜(KRW)'=>'KRW','坡紙(SGD)'=>'SGD', '英鎊(GBP)'=>'GBP','澳元(AUD)'=>'AUD',
		'瑞郎(CHF)'=>'CHF','港元(HKD)'=>'HKD','泰銖(THB)'=>'THB','紐元(NZD)'=>'NZD','台幣(TWD)'=>'TWD'}
		
		hFrame1=FXHorizontalFrame.new(self, :opts => PACK_UNIFORM_WIDTH|FRAME_LINE|LAYOUT_FILL_X)
			vFrame11=FXVerticalFrame.new(hFrame1,:opts=>LAYOUT_FILL_X)
			FXLabel.new(vFrame11, 'From Currency', :opts => LAYOUT_CENTER_X)
			fromcurr=FXOptionMenu.new(vFrame11, currencylist, (FRAME_LINE|ICON_AFTER_TEXT|LAYOUT_CENTER_X))
				
			vFrame12=FXVerticalFrame.new(hFrame1,:opts=>LAYOUT_FILL_Y)
				changeButton=FXButton.new(vFrame12, '<>', :opts => FRAME_LINE|LAYOUT_CENTER_X|LAYOUT_CENTER_Y)
		
			vFrame13=FXVerticalFrame.new(hFrame1,:opts=>LAYOUT_FILL_X)
				FXLabel.new(vFrame13, 'To Currency', :opts => LAYOUT_CENTER_X)
				tocurr=FXOptionMenu.new(vFrame13, currencylist, (FRAME_LINE|ICON_AFTER_TEXT|LAYOUT_CENTER_X))

		vFrame2=FXVerticalFrame.new(self, :opts => LAYOUT_FILL_X|FRAME_LINE)
			FXLabel.new(vFrame2, 'Input the Amount of From Currency',:padLeft=>50)
			hFrame2=FXHorizontalFrame.new(vFrame2, :opts => LAYOUT_FILL_X)
				fTxtfield21=FXTextField.new(hFrame2,5,:opts=>TEXTFIELD_READONLY|FRAME_GROOVE)
				fAmt=FXTextField.new(hFrame2,20,:opts=>LAYOUT_FILL_X|TEXTFIELD_LIMITED|TEXTFIELD_NORMAL)
			FXLabel.new(vFrame2,' ')
			#FXHorizontalSeparator.new(vFrame2, SEPARATOR_RIDGE|LAYOUT_FILL_X)
			fprocessButton=FXButton.new(vFrame2, 'Calcuate',:opts => FRAME_LINE|LAYOUT_CENTER_X)
			FXLabel.new(vFrame2,' ')
			hFrame3=FXHorizontalFrame.new(vFrame2, :opts=>LAYOUT_FILL_X)
				fTxtfield31=FXTextField.new(hFrame3,5,:opts=>TEXTFIELD_READONLY|FRAME_GROOVE)
				fRes=FXTextField.new(hFrame3,20,:opts=>LAYOUT_FILL_X|TEXTFIELD_LIMITED|TEXTFIELD_NORMAL|TEXTFIELD_READONLY)
			#closebutton=FXButton.new(vFrame2,'Close',:opts=>FRAME_LINE|LAYOUT_RIGHT)
								
		fromcurr.connect(SEL_COMMAND) do
			fTxtfield21.text = currencylistform[fromcurr.text]
		end
		tocurr.connect(SEL_COMMAND) do
			fTxtfield31.text = currencylistform[tocurr.text]
		end
		
		changeButton.connect(SEL_COMMAND) do
			fromC = fromcurr.text.to_s
			toC = tocurr.text.to_s
			fromcurr.text=toC
			fTxtfield21.text=currencylistform[fromcurr.text]
			tocurr.text=fromC
			fTxtfield31.text =currencylistform[tocurr.text]
		end
		
		fprocessButton.connect(SEL_COMMAND) do
			if fromcurr.text ==' ' or tocurr.text ==' ' 
				fRes.text = 'No From or To currency input'
			elsif fAmt.text.length == 0
				fRes.text = 'No Amount of currency input'
			elsif fromcurr.text!=' ' and tocurr.text!=' ' and fAmt.text.length > 0
				begin
					cRate = rate(currencylistform[fromcurr.text], currencylistform[tocurr.text])
					fRes.text = (cRate*fAmt.text.gsub(/[^\d^\.]/, '').to_f).to_s
				rescue
					fRes.text = 'Error'
				end
			end
		end
=begin
		closebutton.connect(SEL_COMMAND) do
			FXMainWindow.connect(SEL_CLOSE)
		end
=end
	end
	
	def rate(fromC, toC)
		currcode=fromC+toC
		html_doc=Net::HTTP.get(URI('https://query.yahooapis.com/v1/public/yql?q=SELECT%20*%20FROM%20yahoo.finance.xchange%20WHERE%20pair%3D%22' + currcode + '%22&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys')).to_s
		rate = html_doc.scan(/<Rate>(.*)<\/Rate><Date>/).to_s.strip.gsub(/[^\d^\.]/, '').to_f
	end
	
	def create
		super
		show(PLACEMENT_SCREEN)
	end
end

if __FILE__==$0
	FXApp.new do |app|
		Currencyexchange.new(app)
		app.create
		app.run
	end
end

