# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
$LOAD_PATH.unshift File.expand_path("../../core/lib", __dir__)

require "dotenvcrypt"

require "minitest/autorun"
require "tempfile"
require "fileutils"
