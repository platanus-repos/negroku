require "spec_helper"

module Ask;end

describe "stage cli" do

  context "add command" do

    it "fails with no stage name defined" do
      allow(Ask).to receive(:input).and_return("")
      expect{Negroku::Stage.add}.to raise_error(/required/)
    end

    it "creates the stage file" do
      config = {
        stage_name: "new_stage",
        branch: "test",
        domains: "test.platan.us",
        server_url: "server.url"
      }
      FakeFS::FileSystem.clone(File.join('lib','negroku','templates'))
      FakeFS.activate!
      Dir.mkdir("config")
      Dir.mkdir("config/deploy")

      Negroku::Stage.add_stage_file(config)

      expect(File).to exist("config/deploy/new_stage.rb")
      content = File.read("config/deploy/new_stage.rb")
      expect(content).to match(/NEW_STAGE CONFIGURATION/)
      expect(content).to match(/server 'server.url'/)
      expect(content).to match(/set :branch,\s+'test'/)
      expect(content).to match(/set :nginx_domains,\s+'test.platan.us'/)

      FakeFS.deactivate!
    end

  end

  context "#get_remote_branches" do
    it "gets the remote branches" do
      branches = %q(
        origin/HEAD -> origin/master
        origin/master
        origin/staging
      )
      expect(Negroku::Stage).to receive(:`).with('git branch -r').and_return(branches)

      branches = Negroku::Stage.get_remote_branches
      expect(branches.size).to eq 2
      expect(branches).to include("master")
      expect(branches).to include("staging")
    end

    it "returns an empty array if the command fails" do
      branches = ""
      expect(Negroku::Stage).to receive(:`).with('git branch -r').and_return(branches)

      branches = Negroku::Stage.get_remote_branches
      expect(branches.size).to eq 0
    end

  end

end
