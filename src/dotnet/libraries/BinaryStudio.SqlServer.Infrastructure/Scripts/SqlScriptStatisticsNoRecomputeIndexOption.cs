using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptStatisticsNoRecomputeIndexOption : SqlScriptIndexOption<SqlStatisticsNoRecomputeIndexOption>
        {
        public SqlOnOffValue OnOffValue { get { return Source.OnOffValue; }}

        #region ctor{IServiceProvider,SqlStatisticsNoRecomputeIndexOption}
        public SqlScriptStatisticsNoRecomputeIndexOption(IServiceProvider context,SqlStatisticsNoRecomputeIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }