# frozen_string_literal: true

RSpec.describe Sidekiq::SilentRetry::ServerMiddleware do
  subject(:subject) { described_class.new.call(job_instance, job_payload, queue) { job_code.call } }

  let(:job_instance) { nil }
  let(:queue) { "default" }
  let(:error_class) { StandardError }
  let(:job_code) do
    -> { raise error_class, "some message" }
  end
  let(:job_payload) do
    payload = {
      "retry" => 2,
      "silent_retry" => silent_retry
    }
    payload["retry_count"] = retry_count if retry_count
    payload
  end

  context "when silent retry is off" do
    let(:silent_retry) { false }

    context "when there are retries left" do
      let(:retry_count) { 0 }

      it "raises the error" do
        expect { subject }.to raise_error(StandardError, "some message")
      end
    end

    context "when there are no retries left" do
      let(:retry_count) { 1 }

      it "raises the error" do
        expect { subject }.to raise_error(StandardError, "some message")
      end
    end
  end

  context "when silent retry is on" do
    let(:silent_retry) { true }

    context "when there are retries left" do
      let(:retry_count) { 0 }

      it "raises the silent error" do
        expect { subject }.to raise_error(Sidekiq::SilentRetry.silent_retry_error_class, "some message")
      end
    end

    context "when there are no retries left" do
      let(:retry_count) { 1 }

      it "raises the error" do
        expect { subject }.to raise_error(StandardError, "some message")
      end
    end

    context 'when the job has a warn_after option' do
      let(:job_payload) do
        {
          "retry_count" => retry_count,
          "retry" => 2,
          "silent_retry" => silent_retry,
          "warn_after" => 1
        }
      end

      context 'when the retry count is less than warn_after' do
        let(:retry_count) { 0 }

        it 'silents the error' do
          expect { subject }.to raise_error(Sidekiq::SilentRetry.silent_retry_error_class, "some message")
        end
      end

      context 'when the retry count is equal to warn_after' do
        let(:retry_count) { 1 }

        it 'raises original error' do
          expect { subject }.to raise_error(StandardError, "some message")
        end
      end

      context 'when the retry count is greater than warn_after' do
        let(:retry_count) { 2 }

        it 'raises original error' do
          expect { subject }.to raise_error(StandardError, "some message")
        end
      end
    end
  end

  context "when silent retry is for specific classes" do
    let(:error_class) { NoMethodError }

    let(:silent_retry) { ["NoMethodError"] }

    context "when there are retries left" do
      let(:retry_count) { 0 }

      it "raises the silent error" do
        expect { subject }.to raise_error(Sidekiq::SilentRetry.silent_retry_error_class, "some message")
      end
    end

    context "when there are no retries left" do
      let(:retry_count) { 1 }

      it "raises the error" do
        expect { subject }.to raise_error(StandardError, "some message")
      end
    end
  end
end
