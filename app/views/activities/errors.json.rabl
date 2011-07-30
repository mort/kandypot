node :apiVersion do
 '1.0'
end

node :id do
  Time.now.to_i
end

node :method do
  [params[:controller], params[:action]].join('/')
end


child @activity => :errors do
 
 @activity.errors.each do |k,v|
  node k do
    v
  end
 end
 

end

object false