# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'visual_migrate/relation'

MasterAge.update_or_create([
	{ id: 1, value: '～２２歳' },
	{ id: 2, value: '２３歳～２７歳' },
	{ id: 3, value: '２８歳～３２歳' },
	{ id: 4, value: '３３歳～３７歳' },
	{ id: 5, value: '３８歳～４２歳' },
	{ id: 6, value: '４３歳～４９歳' },
	{ id: 7, value: '５０代' },
	{ id: 8, value: '６０代～' },
])

