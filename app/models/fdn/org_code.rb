#coding: utf-8
# 生成组织机构代码

class Fdn::OrgCode
  COD = {'0' => 0, '1' => 1, '2' => 2, '3' => 3, '4' => 4, '5' => 5, '6' =>6, '7' =>7, '8' =>8,  '9' =>9, 'A'=> 10, 'B' => 11,
               'C' =>12, 'D' => 13, 'E' =>14, 'F' => 15, 'G' =>16, 'H' =>17, 'I' => 18, 'J' =>19, 'K' =>20, 'L' =>21, 'M' =>22,
               'N' =>23, 'O'=>24, 'P' =>25, 'Q'=>26, 'R'=>27, 'S' =>28, 'T' => 29, 'U'=>30, 'V' =>31, 'W'=>32, 'X'=>33, 'Y'=> 34, 'Z' =>35 }
  #加权因子数值
  WI = {1 => 3, 2=> 7, 3 => 9, 4 => 10, 5 => 5, 6=> 8, 7 => 4, 8 => 2 }

  def get_org_code(in_str)
    in_str = in_str.upcase
    #取字符串前8为做转换
    in_str = in_str[0,8]
    sum_for_code = 0
    i = 1
    #本体代码与加权因子对应各位相乘
    #乘积相加求和数
    in_str.each_char do |ch|
      sum_for_code = sum_for_code + (COD[ch] * WI[i])
      i += 1
    end
    #取模数11除和数，求余数
    remain_for_code = 11 - (sum_for_code % 11)
    #以模数11减余数，求校验码数值，当余数为1，校验码数值为10时，校验码用大写拉丁字母“X”表示；
    #当余数为0，校验码数值为11时，校验码用“0”表示；当校验码数值为1至9时，直接用该数值表示
    if remain_for_code == 10
      val_for_code = 'X'
    elsif remain_for_code == 11
        val_for_code = '0'
    else
        val_for_code = remain_for_code.to_s
    end
    return in_str[0,8] + val_for_code
  end

end
