# Laravel Artisan completions for `php artisan`
set -l __fish_artisan_commands \
    about clear-compiled completion db docs down env help inspire \
    invoke-serialized-closure list migrate optimize pail serve test \
    tinker up auth:clear-resets cache:clear cache:forget \
    cache:prune-stale-tags channel:list config:cache config:clear \
    config:publish config:show db:monitor db:seed db:show db:table \
    db:wipe debugbar:clear env:decrypt env:encrypt event:cache \
    event:clear event:generate event:list ide-helper:eloquent \
    ide-helper:generate ide-helper:meta ide-helper:models install:api \
    install:broadcasting key:generate lang:publish make:cache-table \
    make:cast make:channel make:class make:command make:component \
    make:config make:controller make:enum make:event make:exception \
    make:factory make:interface make:job make:job-middleware \
    make:listener make:mail make:middleware make:migration make:model \
    make:notification make:notifications-table make:observer \
    make:policy make:provider make:queue-batches-table \
    make:queue-failed-table make:queue-table make:request make:resource \
    make:rule make:scope make:seeder make:session-table make:test \
    make:trait make:view migrate:fresh migrate:install migrate:refresh \
    migrate:reset migrate:rollback migrate:status model:prune model:show \
    optimize:clear package:discover queue:clear queue:failed queue:flush \
    queue:forget queue:listen queue:monitor queue:prune-batches \
    queue:prune-failed queue:restart queue:retry queue:retry-batch \
    queue:work route:cache route:clear route:list sail:add sail:install \
    sail:publish schedule:clear-cache schedule:finish schedule:interrupt \
    schedule:list schedule:run schedule:test schedule:work schema:dump \
    storage:link storage:unlink stub:publish vendor:publish view:cache \
    view:clear

# Offer `artisan` as the primary php subcommand and block file completions.
complete -c php -n __fish_use_subcommand -a artisan -d 'Laravel Artisan CLI'
complete -c php -n '__fish_seen_subcommand_from artisan' -f
complete -c php -n '__fish_seen_subcommand_from artisan' -a "$__fish_artisan_commands"

# Global Artisan options shared by every command.
complete -c php -n '__fish_seen_subcommand_from artisan' -l help -s h -d 'Display help'
complete -c php -n '__fish_seen_subcommand_from artisan' -l quiet -s q -d 'No output'
complete -c php -n '__fish_seen_subcommand_from artisan' -l verbose -s v -d 'Increase verbosity'
complete -c php -n '__fish_seen_subcommand_from artisan' -l version -s V -d 'Display version'
complete -c php -n '__fish_seen_subcommand_from artisan' -l ansi -d 'Force ANSI output'
complete -c php -n '__fish_seen_subcommand_from artisan' -l no-ansi -d 'Disable ANSI output'
complete -c php -n '__fish_seen_subcommand_from artisan' -l no-interaction -s n -d 'No interactive questions'
complete -c php -n '__fish_seen_subcommand_from artisan' -l env -d Environment

# Yii 2 Framework completions for `php yii`
set -l __fish_yii_commands \
    asset asset/compress asset/template \
    cache cache/flush cache/flush-all cache/flush-schema cache/index \
    fixture fixture/load fixture/unload \
    gii gii/controller gii/crud gii/extension gii/form gii/index gii/model gii/module \
    help help/index help/list help/list-action-options help/usage \
    message message/config message/config-template message/extract \
    migrate migrate/create migrate/down migrate/fresh migrate/history \
    migrate/mark migrate/new migrate/redo migrate/to migrate/up \
    queue queue/clear queue/exec queue/info queue/listen queue/remove queue/run \
    serve serve/index

# Offer `yii` as the primary php subcommand.
complete -c php -n __fish_use_subcommand -a yii -d 'Yii 2 Framework CLI'
complete -c php -n '__fish_seen_subcommand_from yii' -f
complete -c php -n '__fish_seen_subcommand_from yii' -a "$__fish_yii_commands"

# Global Yii options shared by every command.
complete -c php -n '__fish_seen_subcommand_from yii' -l help -s h -d 'Display help'
complete -c php -n '__fish_seen_subcommand_from yii' -l version -s v -d 'Display version'
complete -c php -n '__fish_seen_subcommand_from yii' -l color -d 'Enable ANSI colors'
complete -c php -n '__fish_seen_subcommand_from yii' -l interactive -d 'Enable interactive mode'
complete -c php -n '__fish_seen_subcommand_from yii' -l silent-exit-on-exception -d 'Silent exit on exception'
