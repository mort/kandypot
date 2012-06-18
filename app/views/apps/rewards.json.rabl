node :apiVersion do
 '1.0'
end

node :id do
  Time.now.to_i
end

node :method do
  [params[:controller], params[:action]].join('/')
end

node :context do
  params[:context]
end if params[:context]

object @rewards