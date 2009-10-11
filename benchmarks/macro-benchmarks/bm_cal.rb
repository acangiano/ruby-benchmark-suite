#! /usr/bin/env ruby

# cal.rb: Written by Tadayoshi Funaba 1998-2004,2006,2008
# $Id: cal.rb,v 2.11 2008-01-06 08:42:17+09 tadf Exp $

require 'date'

class Cal

  START =
    {
    'cn' => Date::GREGORIAN, # China
    'de' => 2342032,         # Germany (protestant states)
    'dk' => 2342032,         # Denmark
    'es' => 2299161,         # Spain
    'fi' => 2361390,         # Finland
    'fr' => 2299227,         # France
    'gb' => 2361222,         # United Kingdom
    'gr' => 2423868,         # Greece
    'hu' => 2301004,         # Hungary
    'it' => 2299161,         # Italy
    'jp' => Date::GREGORIAN, # Japan
    'no' => 2342032,         # Norway
    'pl' => 2299161,         # Poland
    'pt' => 2299161,         # Portugal
    'ru' => 2421639,         # Russia
    'se' => 2361390,         # Sweden
    'us' => 2361222,         # United States
    'os' => Date::JULIAN,    # (old style)
    'ns' => Date::GREGORIAN  # (new style)
  }

  DEFAULT_START = 'gb'

  def initialize
    opt_j; opt_m; opt_t; opt_y; opt_c
  end

  def opt_j(flag=false) @opt_j = flag end
  def opt_m(flag=false) @opt_m = flag end
  def opt_t(flag=false) @opt_t = flag end
  def opt_y(flag=false) @opt_y = flag end

  def opt_c(arg=DEFAULT_START) @start = START[arg] end

  def set_params
    @dw = if @opt_j then 3 else 2 end
    @mw = (@dw + 1) * 7 - 1
    @mn = if @opt_j then 2 else 3 end
    @tw = (@mw + 2) * @mn - 2
    @k  = if @opt_m then 1 else 0 end
    @da = if @opt_j then :yday else :mday end
  end

  def pict(y, m)
    d = (1..31).detect{|x| Date.valid_date?(y, m, x, @start)}
    fi = Date.new(y, m, d, @start)
    fi -= (fi.jd - @k + 1) % 7

    ve  = (fi..fi +  6).collect{|cu|
      %w(S M Tu W Th F S)[cu.wday]
    }
    ve += (fi..fi + 41).collect{|cu|
      if cu.mon == m then cu.send(@da) end.to_s
    }

    ve = ve.collect{|e| e.rjust(@dw)}

    gr = group(ve, 7)
    gr = trans(gr) if @opt_t
    ta = gr.collect{|xs| xs.join(' ')}

    ca = %w(January February March April May June July
	    August September October November December)[m - 1]
    ca = ca + ' ' + y.to_s if !@opt_y
    ca = ca.center(@mw)

    ta.unshift(ca)
  end

  def group(xs, n)
    (0..xs.size / n - 1).collect{|i| xs[i * n, n]}
  end

  def trans(xs)
    (0..xs[0].size - 1).collect{|i| xs.collect{|x| x[i]}}
  end

  def stack(xs)
    if xs.empty? then [] else xs[0] + stack(xs[1..-1]) end
  end

  def block(xs, n)
    stack(group(xs, n).collect{|ys| trans(ys).collect{|zs| zs.join('  ')}})
  end

  def unlines(xs)
    xs.collect{|x| x + "\n"}.join
  end

  def monthly(y, m)
    unlines(pict(y, m))
  end

  def addmon(y, m, n)
    y, m = (y * 12 + (m - 1) + n).divmod(12)
    return y, m + 1
  end

  def yearly(y)
    y.to_s.center(@tw) + "\n\n" +
      unlines(block((0..11).collect{|n| pict(*addmon(y, 1, n))}, @mn)) + "\n"
  end

  def print(y, m)
    set_params
    if @opt_y then yearly(y) else monthly(y, m) end
  end

end

Bench.run [500] do |n|
  n.times {
   cal = Cal.new
   cal.print(1980, 11)
 }
end
