/*global module:false*/
module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    pkg: '<json:package.json>',
    meta: {
      name: 'Poezja',
      banner: '/*! <%= pkg.title || pkg.name %> - v<%= pkg.version %> - ' +
        '<%= grunt.template.today("yyyy-mm-dd") %>\n' +
        '<%= pkg.homepage ? "* " + pkg.homepage + "\n" : "" %>' +
        '* Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author.name %>;' +
        ' Licensed <%= _.pluck(pkg.licenses, "type").join(", ") %> */'
    },
    coffeelint: {
      app: ['app/assets/js/**/*.coffee', 'app/assets/js/*.coffee']
    },
    qunit: {
      files: ['test/**/*.html']
    },
    concat: {
      dist: {
        src: ['<banner:meta.banner>', '<file_strip_banner:lib/<%= pkg.name %>.js>'],
        dest: 'dist/<%= pkg.name %>.js'
      }
    },
    handlebars: {
      all: {
        src: 'app/assets/js/templates',
        dest: 'app/public/js/templates.js'
      }
    },
    coffee: {
      compile: {
        files: {
          'app/public/js/*.js': [
            'app/assets/js/*.coffee',
            'app/assets/js/views/*.coffee',
            'app/assets/js/modules/*.coffee',
            'app/assets/js/models/*.coffee',
            'app/assets/js/collections/*.coffee'
            ] // compile individually into dest, maintaining folder structure
          }
        },
        flatten: {
          options: {
            flatten: false
          },
          files: {
            'app/public/js/*.js': [
              'app/assets/js/*.coffee',
              'app/assets/js/views/*.coffee',
              'app/assets/js/modules/*.coffee',
              'app/assets/js/models/*.coffee',
              'app/assets/js/collections/*.coffee'
            ] // compile individually into dest, flattening folder structure
          }
        }
    },
    less: {
      development: {
        options: {
          paths: ["app/assets/css"]
        },
        files: {
          "app/public/css/style.css": "app/assets/css/style.less"
        }
      },
      production: {
        options: {
          paths: ["app/assets/css"],
          yuicompress: true
        },
        files: {
          "app/public/css/style.css": "app/assets/css/style.less"
        }
      }
    },
    min: {
      dist: {
        src: ['<banner:meta.banner>', '<config:concat.dist.dest>'],
        dest: 'dist/<%= pkg.name %>.min.js'
      }
    },
    watch: {
      files: '<config:coffeelint.app>',
      tasks: 'coffeelint coffee:compile less:development reload'
    },
    reload: {
      port: 35729, // LR default
      liveReload: {}
    },
    jshint: {
      options: {
        curly: true,
        eqeqeq: true,
        immed: true,
        latedef: true,
        newcap: true,
        noarg: true,
        sub: true,
        undef: true,
        boss: true,
        eqnull: true,
        browser: true
      },
      globals: {
        jQuery: true
      }
    },
    uglify: {}
  });

  // Default task.
  grunt.loadNpmTasks('grunt-reload');
  grunt.loadNpmTasks('grunt-handlebars');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-less');
  grunt.loadNpmTasks('grunt-coffeelint');
  grunt.registerTask('default', 'coffeelint handlebars coffee:compile less:development');

};
