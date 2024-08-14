--[[
     compose Longest Common Subsequence and Shortest Edit Script.
     The algorithm implemented here is based on "An O(NP) Sequence Comparison Algorithm"                                   
     by described by Sun Wu, Udi Manber and Gene Myers 
--]]
ONP = {}
function ONP.new (a, b)
   local self = {
      A = a,
      B = b,
      M = string.len(a),
      N = string.len(b),
      path       = {},
      pathposi   = {},
      P          = {},
      ses        = {},
      seselem    = {},
      lcs        = "",
      editdis    = 0,
      reverse    = false,
      SES_DELETE = -1,
      SES_COMMON = 0,
      SES_ADD    = 1,
   }
   -- getter
   function self.geteditdistance () 
      return self.editdis
   end
   function self.getlcs ()
      return self.lcs
   end
   function self.getses ()
      return self.ses
   end
   -- constructor
   function self.P.new (x_, y_, k_)
      local self = { x=x_, y=y_, k=k_ }
      return self
   end
   function self.seselem.new (elem_, t_)
      local self = { elem=elem_, t=t_}
      return self
   end
   function self.compose ()
      offset = self.M + 1
      delta  = self.N - self.M
      size   = self.M + self.N + 3
      fp = {}
      for i = 0, size-1 do
         fp[i]   = -1
         self.path[i] = -1
      end
      p = -1
      repeat
         p = p + 1
         for k=-p, delta-1, 1 do
            fp[k+offset] = self.snake(k, fp[k-1+offset]+1, fp[k+1+offset])
         end
         for k=delta+p,delta+1, -1 do
            fp[k+offset] = self.snake(k, fp[k-1+offset]+1, fp[k+1+offset])
         end
         fp[delta+offset] = self.snake(delta, fp[delta-1+offset]+1, fp[delta+1+offset])
      until fp[delta+offset] >= self.N
      self.editdis = delta + 2 * p
      r    = self.path[delta+offset]
      epc  = {}
      while r ~= -1 do
         epc[#epc+1] = self.P.new(self.pathposi[r+1].x, self.pathposi[r+1].y, nil)
         r = self.pathposi[r+1].k
      end
      self.recordseq(epc)
   end
   function self.recordseq (epc)
      x_idx,  y_idx  = 1, 1
      px_idx, py_idx = 0, 0
      for i=#epc, 1, -1 do
         while (px_idx < epc[i].x or py_idx < epc[i].y) do
            t = nil
            if (epc[i].y - epc[i].x) > (py_idx - px_idx) then
               elem = string.sub(self.B, y_idx, y_idx)
               if self.reverse then 
                  t = self.SES_DELETE
               else
                  t = self.SES_ADD
               end
               self.ses[#self.ses+1] = self.seselem.new(elem, t)
               y_idx  = y_idx  + 1
               py_idx = py_idx + 1
            elseif epc[i].y - epc[i].x < py_idx - px_idx then
               elem = string.sub(self.A, x_idx, x_idx)
               if self.reverse then 
                  t = self.SES_ADD
               else
                  t = self.SES_DELETE
               end
               self.ses[#self.ses+1] = self.seselem.new(elem, t)
               x_idx  = x_idx  + 1
               px_idx = px_idx + 1
            else 
               elem = string.sub(self.A, x_idx, x_idx)
               t = self.SES_COMMON
               self.lcs = self.lcs .. elem
               self.ses[#self.ses+1] = self.seselem.new(elem, t)
               x_idx  = x_idx  + 1
               y_idx  = y_idx  + 1
               px_idx = px_idx + 1
               py_idx = py_idx + 1
            end
         end
      end
   end
   function self.snake (k, p, pp)
      r = 0;
      if p > pp then
         r = self.path[k-1+offset];
      else
         r = self.path[k+1+offset];
      end
      y = math.max(p, pp);
      x = y - k
      while (x < self.M and y < self.N and 
             string.sub(self.A, x+1, x+1) == string.sub(self.B, y+1, y+1)) 
      do
         x = x + 1
         y = y + 1
      end
      self.path[k+offset] = #self.pathposi
      p = self.P.new(x, y, r)
      self.pathposi[#self.pathposi+1] = p
      return y
   end
   if self.M >= self.N then
      self.A, self.B = self.B, self.A
      self.M, self.N = self.N, self.M
      self.reverse = true
   end
   return self
end

local arg = {
    'Inflicts 110,387 Nature damage instantly and an additional 22,077 Nature damage every 2 sec for 20sec to players standing in the impact area.',
    'Inflicts 1.7 million Nature damage to players standing in the impact area.'
}

if #arg < 2 then
    error("few argument")
 end
 a = arg[1]
 b = arg[2]
 local startTime = GetTimePreciseSec()
 d = ONP.new(a, b)
 d:compose()
 --print("editDistance:" .. d:geteditdistance())
 --print("LCS:" .. d:getlcs())
-- print("SES")
 ses = d:getses()
 local endTime = GetTimePreciseSec()

 local counter = 1

 local base, diff1, diff2 = "", "", ""

 local changing = false

 local changeStarted = false

 local words = {}

 local startIndex, endIndex

 for i=1, #ses do
    local lastOperator = ses[i-1] and ses[i-1].t or nil
    local currentOperator = ses[i].t
    local nextOperator = ses[i+1] and ses[i+1].t or nil

    local wasFalse = changeStarted == false

    if(nextOperator ~= d.SES_COMMON) then
        changeStarted = true
    end

    if(ses[i].elem == " ") then
        changeStarted = false
    end

    if currentOperator == d.SES_COMMON then
        --print(i, "  " .. ses[i].elem)

        if(nextOperator and nextOperator ~= d.SES_COMMON or changeStarted) then

            diff1 = diff1 .. ses[i].elem
            diff2 = diff2 .. ses[i].elem
            
            if(wasFalse) then
                base = base .. "[" .. counter .. "]"
                counter = counter + 1
            end

            if(ses[i].elem == " ") then

                base = base .. ses[i].elem
                
            else

            end
            
        else
            base = base .. ses[i].elem

        end

    elseif currentOperator == d.SES_DELETE then
        --print(i, "- " .. ses[i].elem)

        diff1 = diff1 .. ses[i].elem

    elseif currentOperator == d.SES_ADD then
        --print(i, "+ " .. ses[i].elem)

        diff2 = diff2 .. ses[i].elem
    end
 end

----print(base)
--print("----" .. diff1 .. "----")
--print("----" .. diff2 .. "----")

 --print("TIME: " .. (endTime-startTime))