# Copyright (C) 2016-Present Pivotal Software, Inc. All rights reserved.
# This program and the accompanying materials are made available under the terms of the under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

require 'spec_helper'

RSpec.describe 'collect-service-metrics script' do
  let(:renderer) do
    links = [{
      'broker' => {
        'instances' => [
          {
            'address' => "123.456.789.101",
          }
        ],
        'properties' => {
          'username' => "%username'\"t:%!",
          'password' => "%password'\"t:%!",
          'port' => 7070
        }
      }
    }]
    merged_context = BoshEmulator.director_merge(YAML.load_file(manifest_file), 'service-metrics-adapter', links)
    Bosh::Template::Renderer.new(context: merged_context.to_json)
  end

  let(:rendered_template) { renderer.render('jobs/service-metrics-adapter/templates/collect-service-metrics.sh.erb') }

  context 'when the broker credentials contain special characters' do
    let(:manifest_file) { 'spec/fixtures/collect_service_metrics_with_special_characters.yml' }

    it 'escapes the broker credentials' do
      expect(rendered_template).to include "-brokerUsername '%username'\\''\"t:%!'"
      expect(rendered_template).to include "-brokerPassword '%password'\\''\"t:%!'"
    end
  end

  context 'when the broker uri is configured' do
    let(:manifest_file) { 'spec/fixtures/collect_service_metrics_with_special_characters.yml' }

    it 'uses the configured broker uri' do
      expect(rendered_template).to include '-brokerUrl http://example.com:8080'
    end
  end

  context 'when the broker uri property is missing' do
    let(:manifest_file) { 'spec/fixtures/collect_service_metrics_without_broker_uri.yml' }

    it 'uses the broker job link' do
      expect(rendered_template).to include '-brokerUrl http://123.456.789.101:7070'
    end
  end
end
