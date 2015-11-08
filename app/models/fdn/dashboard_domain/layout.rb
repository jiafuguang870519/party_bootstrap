#coding: utf-8
############
# layout includes rows
# rows includes columns
# columns includes widgets or rows
class Fdn::DashboardDomain::Layout
  # To change this template use File | Settings | File Templates.
  attr_accessor :rows

  def initialize(rows=[])
    self.rows = rows
  end

  def to_s
    output = '<div class="widget-layout">'
    rows.each do |r|
      output << r.to_s
    end
    output << '</div>'
    output <<
      %q(
      <script type="text/javascript">
        $(document).ready(function () {
            //$(".widget-column").sortable({
            //    connectWith:'.widget-column'
            //});

            //$(".widget-column").disableSelection();
            //$(".widget-content").disableSelection();
        });
      </script>
      )

    output
  end
end