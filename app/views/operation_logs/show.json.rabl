node :apiVersion do
 '1.0'
end

node :id do
  Time.now.to_i
end

node :method do
  [params[:controller], params[:action]].join('/')
end


child @op => :data do
 
  @op.data.each do |k,v|
    node k do
      v
    end
  end

   node :kind do
    'OperationLog'
    # DateTime.parse(@activity.updated_at.to_s).rfc3339
   end
 
end

object false