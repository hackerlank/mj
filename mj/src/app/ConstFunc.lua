--触摸偏移量--
function touchMoveDistance(x1,y1,x2,y2,dis)
  local ret = false
  local dis_ = dis or 15
  if math.sqrt(math.pow(x1 - x2,2)+math.pow(y1 - y2,2)) > dis_ then
    ret = true
  end
  return ret 
end