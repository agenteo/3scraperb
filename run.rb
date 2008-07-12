require 'rubygems'
require 'mechanize'

CREDENTIALS = {}
############################################
# change the values with your credentials...
CREDENTIALS[:PHONE_NUMBER] = "your phone number here"
CREDENTIALS[:ACCOUNT_PASSWORD] = "the account password here"
CREDENTIALS[:PIN] = "your pin here"
############################################
############################################

agent = WWW::Mechanize.new

# first step login page...
page = agent.get("https://www.my.three.com.au/My3/jfn")
login_form = page.forms.with.name("login").first
login_form.login = CREDENTIALS[:PHONE_NUMBER]
login_form.password = CREDENTIALS[:ACCOUNT_PASSWORD]
login_result = agent.submit(login_form)

# ok now they want the pin...
pin_form = login_result.forms.with.name("myForm").first
pin_form.pin = CREDENTIALS[:PIN]
search_results = agent.submit(pin_form)

# the first bloody iframe...
iframe_link = search_results.iframes.src

page_with_mobile = agent.get("https://www.my.three.com.au/My3/#{iframe_link}")

# click on the mobile for details...
link_to_results_page = page_with_mobile.links.text(Regexp.new(CREDENTIALS[:PHONE_NUMBER]))
results_page = agent.click(link_to_results_page)

# the second bloody iframe...
iframe_link = results_page.iframes.src
final_page = agent.get("https://www.my.three.com.au/My3/#{iframe_link}")

# the final page with the stats...
final_page = Hpricot(final_page.body)

broadband = {}

# broadband on net...
broadband[:on_net] = {}
broadband[:on_net][:plan_name] = final_page.search("//table[@class='my3BorderDataTable']//tr:eq(1)//td:eq(0)//span").inner_html.strip
broadband[:on_net][:remaining_data] = final_page.search("//table[@class='my3BorderDataTable']//tr:eq(1)//td:eq(1)").inner_html.strip
broadband[:on_net][:expire_date] = final_page.search("//table[@class='my3BorderDataTable']//tr:eq(1)//td:eq(2)//span").inner_html.strip

# broadband on roaming...
broadband[:on_roaming] = {}
broadband[:on_roaming][:plan_name] = final_page.search("//table[@class='my3BorderDataTable']//tr:eq(2)//td:eq(0)//span").inner_html.strip
broadband[:on_roaming][:remaining_data] = final_page.search("//table[@class='my3BorderDataTable']//tr:eq(2)//td:eq(1)").inner_html.strip
broadband[:on_roaming][:expire_date] = final_page.search("//table[@class='my3BorderDataTable']//tr:eq(2)//td:eq(2)//span").inner_html.strip

updated_on = final_page.search("//td[@class='my3ExtraInfo']").inner_html.strip

# print results...
puts "#" * 80
puts "**#{broadband[:on_net][:remaining_data]}** left on #{broadband[:on_net][:plan_name]} expiring on **#{broadband[:on_net][:expire_date]}**"
puts "#{broadband[:on_roaming][:remaining_data]} left on #{broadband[:on_roaming][:plan_name]} expiring on #{broadband[:on_roaming][:expire_date]}"
puts "_" * 80
puts "#{updated_on}"
puts "#" * 80
