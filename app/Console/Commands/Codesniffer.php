<?php
namespace App\Console\Commands;

use Illuminate\Console\Command;

class Codesniffer extends Command
{
    /**
     * {@inheritdoc}
     */
    protected $name = "code-sniffer";

    /**
     * {@inheritdoc}
     */
    protected $description = "CodeSniffer sniffs only modified php files";

    /**
     * @return void
     */
    public function fire()
    {
        $command = "git diff --name-only --diff-filter=ACMR origin/develop...HEAD";
        $command .= "| egrep -v 'database/|resources/|provision/'";
        $command .= "| grep .php";
        exec($command, $output);

        $this->grepDiffForDebugCode();

        // remain the same
        if (empty($output)) {
            $this->info("CodeSniffer has nothing to do.");
            return;
        }

        $this->info("CodeSniffer sniffs files below...\n\n" . implode("\n", $output) . "\n---\n");

        $targetFiles = implode(" ", $output);
        $command = "vendor/bin/phpcs --standard=./phpcs.xml " . $targetFiles;

        exec($command, $output, $return);

        if ($return === 0) {
            $this->info("Your codes are based on PSR-2, Yeah.");
            return;
        } else {
            $this->error(implode("\n", $output));
            exit(1);
        }
    }

    private function grepDiffForDebugCode()
    {
        $filesCmd = 'git diff --name-only|grep -v Codesniffer.php';

        exec($filesCmd, $files);

        foreach ($files as $file) {
            exec("git diff $file", $out);
            if (count($out)) {
                $this->info("Debug Code found in $file");
                exit(1);
            }
        }
    }
}
