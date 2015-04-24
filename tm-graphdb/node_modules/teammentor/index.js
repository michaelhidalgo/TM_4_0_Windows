/*jslint node: true */
"use strict";

// adding coffee-script support, after this line we can import *.coffee files
require('coffee-script/register');

exports.Cache_Service      = require('./src/services/Cache-Service')
exports.GitHub_Service     = require('./src/services/GitHub-Service')
exports.Jade_Service       = require('./src/services/Jade-Service')
exports.TeamMentor_Service = require('./src/services/TeamMentor-Service')

exports.Guid               = require('./src/Vis/Guid')
exports.Vis_Edge           = require('./src/Vis/Vis-Edge')
exports.Vis_Graph          = require('./src/Vis/Vis-Graph')
exports.Vis_Node           = require('./src/Vis/Vis-Node')
exports.Vis_Options        = require('./src/Vis/Vis-Options')
