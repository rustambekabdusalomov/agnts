//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/notify_settings.dart';
import 'package:agnts_api/src/model/pr_comment_settings.dart';
import 'package:agnts_api/src/model/ci_settings.dart';
import 'package:agnts_api/src/model/guard_settings.dart';
import 'package:agnts_api/src/model/pull_review_settings.dart';
import 'package:agnts_api/src/model/stage_models.dart';
import 'package:agnts_api/src/model/git_settings.dart';
import 'package:agnts_api/src/model/effort_settings.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'settings.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Settings {
  /// Returns a new [Settings] instance.
  Settings({

    required  this.models,

    required  this.maxTurns,

     this.runBudget,

    required  this.timeoutMin,

    required  this.allow,

    required  this.deny,

    required  this.askFirst,

    required  this.autoResume,

     this.autoLearn,

     this.autoReview,

     this.autoPreview,

     this.visualCheck,

     this.autoBrief,

     this.publicDocuments,

     this.selfReview,

     this.reflect,

     this.egressAllow,

     this.suggestFollowUps,

     this.maxTicketRepos,

     this.pullReviews,

     this.prComments,

     this.ci,

     this.guard,

     this.stalls,

     this.proveFixes,

     this.methodSkills,

     this.deepReview,

     this.learnFromRuns,

     this.effort,

     this.recheckComplex,

     this.baselineChecks,

     this.secondOpinion,

    required  this.pauseAbove,

    required  this.parallel,

    required  this.git,

     this.notify,
  });

  @JsonKey(
    
    name: r'models',
    required: true,
    includeIfNull: false,
  )


  final StageModels models;



          // minimum: 20
          // maximum: 200
  @JsonKey(
    
    name: r'maxTurns',
    required: true,
    includeIfNull: false,
  )


  final int maxTurns;



      /// The most one run on credits may spend, in credits (1 credit = $0.01); 0 leaves the server cap
          // minimum: 0
          // maximum: 1000000
  @JsonKey(
    
    name: r'runBudget',
    required: false,
    includeIfNull: false,
  )


  final int? runBudget;



          // minimum: 10
          // maximum: 120
  @JsonKey(
    
    name: r'timeoutMin',
    required: true,
    includeIfNull: false,
  )


  final int timeoutMin;



  @JsonKey(
    
    name: r'allow',
    required: true,
    includeIfNull: false,
  )


  final List<String> allow;



  @JsonKey(
    
    name: r'deny',
    required: true,
    includeIfNull: false,
  )


  final List<String> deny;



  @JsonKey(
    
    name: r'askFirst',
    required: true,
    includeIfNull: false,
  )


  final bool askFirst;



  @JsonKey(
    
    name: r'autoResume',
    required: true,
    includeIfNull: false,
  )


  final bool autoResume;



      /// Learn from every pushed ticket
  @JsonKey(
    
    name: r'autoLearn',
    required: false,
    includeIfNull: false,
  )


  final bool? autoLearn;



      /// Review every result while it waits for review
  @JsonKey(
    
    name: r'autoReview',
    required: false,
    includeIfNull: false,
  )


  final bool? autoReview;



      /// Take screenshots of every UI change in repositories with a preview command
  @JsonKey(
    
    name: r'autoPreview',
    required: false,
    includeIfNull: false,
  )


  final bool? autoPreview;



      /// Coding runs may start the app and look at the pages they changed
  @JsonKey(
    
    name: r'visualCheck',
    required: false,
    includeIfNull: false,
  )


  final bool? visualCheck;



      /// Survey a repository without a brief when its first ticket is analysed, and refresh the brief after merges
  @JsonKey(
    
    name: r'autoBrief',
    required: false,
    includeIfNull: false,
  )


  final bool? autoBrief;



      /// Let documents have public links; off makes every public link of the workspace stop working
  @JsonKey(
    
    name: r'publicDocuments',
    required: false,
    includeIfNull: false,
  )


  final bool? publicDocuments;



      /// Send blocker and major findings of agnts's code review back to the coder once per revision, before a person reviews
  @JsonKey(
    
    name: r'selfReview',
    required: false,
    includeIfNull: false,
  )


  final bool? selfReview;



      /// Learn from change requests and rejections: suggest rules, which apply once someone adopts them
  @JsonKey(
    
    name: r'reflect',
    required: false,
    includeIfNull: false,
  )


  final bool? reflect;



      /// Hosts run containers may reach besides the built-in list, such as a staging API; .example.com matches subdomains
  @JsonKey(
    
    name: r'egressAllow',
    required: false,
    includeIfNull: false,
  )


  final List<String>? egressAllow;



      /// Runs suggest follow-up tickets (off by default; a ticket can override it)
  @JsonKey(
    
    name: r'suggestFollowUps',
    required: false,
    includeIfNull: false,
  )


  final bool? suggestFollowUps;



      /// How many repositories one ticket, and one repository group, may have (6 by default)
          // minimum: 1
          // maximum: 20
  @JsonKey(
    
    name: r'maxTicketRepos',
    required: false,
    includeIfNull: false,
  )


  final int? maxTicketRepos;



  @JsonKey(
    
    name: r'pullReviews',
    required: false,
    includeIfNull: false,
  )


  final PullReviewSettings? pullReviews;



  @JsonKey(
    
    name: r'prComments',
    required: false,
    includeIfNull: false,
  )


  final PRCommentSettings? prComments;



  @JsonKey(
    
    name: r'ci',
    required: false,
    includeIfNull: false,
  )


  final CISettings? ci;



  @JsonKey(
    
    name: r'guard',
    required: false,
    includeIfNull: false,
  )


  final GuardSettings? guard;



      /// What agnts does when a run looks stuck: nothing, note it on the ticket, or also tell Claude to step back (once per run)
  @JsonKey(
    
    name: r'stalls',
    required: false,
    includeIfNull: false,
  )


  final String? stalls;



      /// Bug fixes need a test that fails before the change and passes after it; agnts checks it
  @JsonKey(
    
    name: r'proveFixes',
    required: false,
    includeIfNull: false,
  )


  final bool? proveFixes;



      /// Coding runs get agnts's method skills: add one more of something the way the repository does, follow its style, reuse before writing, change a schema safely
  @JsonKey(
    
    name: r'methodSkills',
    required: false,
    includeIfNull: false,
  )


  final bool? methodSkills;



      /// Specialist passes in the code review (security, silent failures, tests, types); auto: large or complex work
  @JsonKey(
    
    name: r'deepReview',
    required: false,
    includeIfNull: false,
  )


  final String? deepReview;



      /// Suggest tips from runs that had trouble (failed checks, a stall)
  @JsonKey(
    
    name: r'learnFromRuns',
    required: false,
    includeIfNull: false,
  )


  final bool? learnFromRuns;



  @JsonKey(
    
    name: r'effort',
    required: false,
    includeIfNull: false,
  )


  final EffortSettings? effort;



      /// The coding model re-checks the analysis of a ticket the analysis model rated complex, before any code is written
  @JsonKey(
    
    name: r'recheckComplex',
    required: false,
    includeIfNull: false,
  )


  final bool? recheckComplex;



      /// Run the checks on the commit a ticket starts from before its first coding run: what fails there is not the ticket's to fix
  @JsonKey(
    
    name: r'baselineChecks',
    required: false,
    includeIfNull: false,
  )


  final bool? baselineChecks;



      /// A model that critiques the chosen approach of complex tickets (codex:<model> or a Claude model); empty turns it off
  @JsonKey(
    
    name: r'secondOpinion',
    required: false,
    includeIfNull: false,
  )


  final String? secondOpinion;



          // minimum: 50
          // maximum: 100
  @JsonKey(
    
    name: r'pauseAbove',
    required: true,
    includeIfNull: false,
  )


  final int pauseAbove;



          // minimum: 1
          // maximum: 3
  @JsonKey(
    
    name: r'parallel',
    required: true,
    includeIfNull: false,
  )


  final int parallel;



  @JsonKey(
    
    name: r'git',
    required: true,
    includeIfNull: false,
  )


  final GitSettings git;



  @JsonKey(
    
    name: r'notify',
    required: false,
    includeIfNull: false,
  )


  final NotifySettings? notify;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Settings &&
      other.models == models &&
      other.maxTurns == maxTurns &&
      other.runBudget == runBudget &&
      other.timeoutMin == timeoutMin &&
      other.allow == allow &&
      other.deny == deny &&
      other.askFirst == askFirst &&
      other.autoResume == autoResume &&
      other.autoLearn == autoLearn &&
      other.autoReview == autoReview &&
      other.autoPreview == autoPreview &&
      other.visualCheck == visualCheck &&
      other.autoBrief == autoBrief &&
      other.publicDocuments == publicDocuments &&
      other.selfReview == selfReview &&
      other.reflect == reflect &&
      other.egressAllow == egressAllow &&
      other.suggestFollowUps == suggestFollowUps &&
      other.maxTicketRepos == maxTicketRepos &&
      other.pullReviews == pullReviews &&
      other.prComments == prComments &&
      other.ci == ci &&
      other.guard == guard &&
      other.stalls == stalls &&
      other.proveFixes == proveFixes &&
      other.methodSkills == methodSkills &&
      other.deepReview == deepReview &&
      other.learnFromRuns == learnFromRuns &&
      other.effort == effort &&
      other.recheckComplex == recheckComplex &&
      other.baselineChecks == baselineChecks &&
      other.secondOpinion == secondOpinion &&
      other.pauseAbove == pauseAbove &&
      other.parallel == parallel &&
      other.git == git &&
      other.notify == notify;

    @override
    int get hashCode =>
        models.hashCode +
        maxTurns.hashCode +
        runBudget.hashCode +
        timeoutMin.hashCode +
        allow.hashCode +
        deny.hashCode +
        askFirst.hashCode +
        autoResume.hashCode +
        autoLearn.hashCode +
        autoReview.hashCode +
        autoPreview.hashCode +
        visualCheck.hashCode +
        autoBrief.hashCode +
        publicDocuments.hashCode +
        selfReview.hashCode +
        reflect.hashCode +
        egressAllow.hashCode +
        suggestFollowUps.hashCode +
        maxTicketRepos.hashCode +
        pullReviews.hashCode +
        prComments.hashCode +
        ci.hashCode +
        guard.hashCode +
        stalls.hashCode +
        proveFixes.hashCode +
        methodSkills.hashCode +
        deepReview.hashCode +
        learnFromRuns.hashCode +
        effort.hashCode +
        recheckComplex.hashCode +
        baselineChecks.hashCode +
        secondOpinion.hashCode +
        pauseAbove.hashCode +
        parallel.hashCode +
        git.hashCode +
        notify.hashCode;

  factory Settings.fromJson(Map<String, dynamic> json) => _$SettingsFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

