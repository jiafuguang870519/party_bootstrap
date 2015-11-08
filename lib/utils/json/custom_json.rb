#coding: utf-8
# To change this template, choose Tools | Templates
# and open the template in the editor.

class CustomJson
  AUTOCOMPLETE_COLS = ['id', 'label', 'value']
  AUTOCOMPLETE_COLS_CODE = ['id', 'label', 'value', 'code']
  AUTOCOMPLETE_COLS_MANY = ['id', 'label', 'value', 'gov_inv_name','gov_inv_id','ent_level_value','ent_level_code','sasac_dept_name','sasac_dept_id','dept_id_name','dept_id','is_outside_to_inside_value','is_outside_to_inside']

  def self.autocomplete_json(instance_lists, methods)
    temp_arr = []

    instance_lists.each do |list|
      temp_hash = {}
      i = 0
      if methods.size == 3
        methods.each do |method|
          temp_hash = temp_hash.merge({AUTOCOMPLETE_COLS[i] => list.send(method).to_s})
          i += 1
        end
      elsif methods.size == 13
        methods.each do |method|
          temp_hash = temp_hash.merge({AUTOCOMPLETE_COLS_MANY[i] => list.send(method).to_s})
          i += 1
        end
      else
        methods.each do |method|
          temp_hash = temp_hash.merge({AUTOCOMPLETE_COLS_CODE[i] => list.send(method).to_s})
          i += 1
        end
      end
      temp_arr << temp_hash
    end
    temp_arr.to_json
  end
end
