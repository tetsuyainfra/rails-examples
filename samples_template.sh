#!/bin/bash

rails new DeviseSample -m rails-templates/apply_devise.rb      --skip-javascript --skip-spring
rails new BlogSample   -m rails-templates/apply_simple_blog.rb --skip-javascript --skip-spring
rails new CanSample    -m rails-templates/apply_cancancan.rb   --skip-javascript --skip-spring
rails new PunSample    -m rails-templates/apply_pundit.rb   --skip-javascript --skip-spring
