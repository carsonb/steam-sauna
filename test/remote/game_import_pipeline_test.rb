require 'test_helper'

module Remote
  class GameImportPipelineTest < Remote::Test

    test "importing a list of games through the pipeline" do
      apps = Remote::Test::APPS
      app_ids = apps.keys
      pipeline = GameImportPipeline.new
      pipeline.logger = Rails.logger

      assert_difference "SteamGame.count", app_ids.length do
        assert pipeline.import(app_ids), "The pipeline threw an error or failed to import all the apps"
      end

      apps.each do |app_id, title|
        game = SteamGame.find_by(app_id: app_id)
        assert_equal(title, game.title)
      end
    end
  end
end
