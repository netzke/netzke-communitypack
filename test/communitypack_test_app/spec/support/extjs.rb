require 'spec_helper'

# Some helper methods to verify attributes of Ext JS components
module Extjs

  # Returns the number of records in the datagrid's store
  #
  # @return [Fixnum] 
  def grid_count
    wait_for_ajax do
      page.driver.browser.execute_script(<<-JS)
        return Ext.ComponentQuery.query('gridpanel')[0].getStore().getCount();
      JS
    end
  end

  # Returns the value of a cell in the datagrid
  #
  # @param [Fixnum] index The row
  # @param [Symbol] attribute The column
  # @return [String]
  def grid_cell_value(index, attribute)
    wait_for_ajax do
      page.driver.browser.execute_script(<<-JS)
        return Ext.ComponentQuery.query('gridpanel')[0].getStore().getAt(#{index}).get('#{attribute}');
      JS
    end
  end

  # Waits unitl there are no ajax requestes and yields to block
  #
  # @param block
  def wait_for_ajax(&block)
    wait_until do
      page.driver.browser.execute_script(<<-JS)
        return !Ext.Ajax.isLoading();
      JS
    end
    yield
  end

end