module CurationConcerns
  module AdminControllerBehavior
    extend ActiveSupport::Concern

    included do
      cattr_accessor :configuration
      self.configuration = CurationConcerns.config.dashboard_configuration
      before_action :require_permissions
      before_action :load_configuration
      layout "admin"

      def index
        @resource_statistics = @configuration.fetch(:data_sources).fetch(:resource_stats).new
        render 'index'
      end
    end

    def search_builder
      @search_builder ||= ::CatalogController.new.search_builder
    end

    def repository
      @repository ||= ::CatalogController.new.repository
    end

    private

      def require_permissions
        authorize! :read, :admin_dashboard
      end

      def load_configuration
        @configuration = self.class.configuration.with_indifferent_access
      end

      # Loads the index action if it's only defined in the configuration.
      def action_missing(action)
        index if @configuration[:actions].include?(action)
      end
  end
end
