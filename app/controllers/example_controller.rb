# app/controllers/example_controller.rb
class ExampleController < ApplicationController
    def hello_world
      render json: { message: 'Hello, world!' }
    end
  end
  