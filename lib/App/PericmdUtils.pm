package App::PericmdUtils;

use 5.010001;
use strict;
use warnings;

# AUTHORITY
# DATE
# DIST
# VERSION

our %SPEC;

$SPEC{list_pericmd_plugins} = {
    v => 1.1,
    summary => "List Perinci::CmdLine plugins",
    description => <<'_',

This utility lists Perl modules in the `Perinci::CmdLine::Plugin::*` namespace.

_
    args => {
        # XXX use common library
        detail => {
            schema => 'bool*',
            cmdline_aliases => {l=>{}},
        },
    },
};
sub list_pericmd_plugins {
    require Module::List::Tiny;
    my %args = @_;

    my $mods = Module::List::Tiny::list_modules(
        "Perinci::CmdLine::Plugin::",
        {list_modules => 1, recurse=>1},
    );

    my @rows;
    for my $mod (sort keys %$mods) {
        my $name = $mod; $name =~ s/^Perinci::CmdLine::Plugin:://;
        my $row = {name => $name};
        if ($args{detail}) {
            #require Module::Abstract;
            #$row->{abstract} = Module::Abstract::module_abstract($mod);

            (my $modpm = "$mod.pm") =~ s!::!/!g;
            require $modpm;
            my $meta = $mod->meta;
            $row->{summary} = $meta->{summary};
            $row->{conf} = join(", ", sort keys %{$meta->{conf}});
            $row->{tags} = join(", ", @{$meta->{tags}});

            require Package::Stash;
            my $stash = Package::Stash->new($mod);
            $row->{hooks} = join(", ", (grep /^(on_|after_|before_)/, $stash->list_all_symbols('CODE')));

            {
                no strict 'refs'; ## no critic: TestingAndDebugging::ProhibitNoStrict
                $row->{dist} = ${"$mod\::DIST"};
            }
        }
        push @rows, $row;
    }

    my %resmeta;
    if ($args{detail}) {
        $resmeta{'table.fields'} = ['name', 'summary'];
    } else {
        @rows = map { $_->{name} } @rows;
    }

    [200, "OK", \@rows, \%resmeta];
}

1;
#ABSTRACT: Some utilities related to Perinci::CmdLine

=head1 DESCRIPTION

This distribution includes a few utility scripts related to Perinci::CmdLine
modules family.

#INSERT_EXECS_LIST


=head1 SEE ALSO

L<Perinci>

L<App::PerinciUtils>

=cut
