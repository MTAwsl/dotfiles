_: {
  flake.modules.users.yuri.home.oac-models =
    _:
    let
      proReasoningModel = "openai/gpt-5.5-pro";
      reasoningModel = "openai/gpt-5.5";
      defaultModel = "openai/gpt-5.5-fast";
      codingModel = "openai/gpt-5.3-codex";
      fastCodingModel = "openai/gpt-5.3-codex-spark";
      scoutModel = "openai/gpt-5.4-mini-fast";
      contentModel = "openai/gpt-5.4-fast";
      dataModel = "openai/gpt-5.4";
      utilityModel = "openai/gpt-5.4-mini-fast";

      highReasoning = {
        model = proReasoningModel;
        reasoningEffort = "high";
        textVerbosity = "low";
      };

      reasoning = {
        model = reasoningModel;
        reasoningEffort = "medium";
        textVerbosity = "low";
      };
    in
    {
      programs.opencode.settings = {
        model = defaultModel;
        small_model = utilityModel;

        agent = {
          build.model = codingModel;
          plan = highReasoning;
          general.model = defaultModel;
          explore.model = scoutModel;
          scout.model = scoutModel;
          compaction.model = utilityModel;
          title.model = utilityModel;
          summary.model = utilityModel;

          OpenAgent.model = defaultModel;
          OpenCoder.model = codingModel;
          OpenSystemBuilder = highReasoning;
          OpenRepoManager = reasoning;
          "Eval Runner".model = utilityModel;

          OpenTechnicalWriter.model = contentModel;
          OpenCopywriter.model = contentModel;
          OpenDataAnalyst.model = dataModel;

          TaskManager = reasoning;
          DocWriter.model = contentModel;
          ContextScout.model = scoutModel;
          ExternalScout.model = scoutModel;
          "Context Retriever".model = scoutModel;

          CoderAgent.model = codingModel;
          BuildAgent.model = fastCodingModel;
          TestEngineer.model = fastCodingModel;
          CodeReviewer = reasoning;
          OpenFrontendSpecialist.model = codingModel;
          OpenDevopsSpecialist.model = codingModel;

          DomainAnalyzer = reasoning;
          AgentGenerator.model = fastCodingModel;
          ContextOrganizer.model = scoutModel;
          WorkflowDesigner = reasoning;
          CommandCreator.model = fastCodingModel;

          "Image Specialist".model = defaultModel;
        };
      };
    };
}
