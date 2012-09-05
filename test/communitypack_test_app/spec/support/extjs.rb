require 'spec_helper'

# Some helper methods to verify attributes of Ext JS components
module Extjs

  # Returns the number of records in the datagrid's store
  #
  # @return [Fixnum] 
  def grid_count
    wait_for_ajax do
      page.driver.browser.execute_script(<<-JS)
        return Ext.ComponentQuery.query('gridpanel, treepanel')[0].getStore().getCount();
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
        return Ext.ComponentQuery.query('gridpanel, treepanel')[0].getStore().getAt(#{index}).get('#{attribute}');
      JS
    end
  end

  # Expands a node in the treepanel
  #
  # @param [Fixnum] id The id of the node
  def expand_node(id)
    wait_for_ajax do
      page.driver.browser.execute_script(<<-JS)
        Ext.ComponentQuery.query('treepanel')[0].getStore().getNodeById('#{id}').expand();
      JS
    end
  end

  # Retrieves the number of children of a node
  #
  # @param [Fixnum] id The id of the node
  def children_count(id)
    wait_for_ajax do
      page.driver.browser.execute_script(<<-JS)
        return Ext.ComponentQuery.query('treepanel')[0].getStore().getNodeById('#{id}').childNodes.length;
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