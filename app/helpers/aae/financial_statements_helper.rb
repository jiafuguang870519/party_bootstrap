#coding: utf-8
module Aae::FinancialStatementsHelper


  def aae_view_link(fs)
    [
        {value: '查看', url: url_for(:controller => 'aae/financial_statements', :action => :show, :id => fs.id)},
        {value: '编辑', url: url_for(:controller => 'aae/financial_statements', :action => :edit, :id => fs.id)}
    ]
  end
end
