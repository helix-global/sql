using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptStatisticsIncrementalIndexOption : SqlScriptIndexOption<SqlStatisticsIncrementalIndexOption>
        {
        public SqlOnOffValue OnOffValue { get { return Source.OnOffValue; }}

        #region ctor{IServiceProvider,SqlStatisticsIncrementalIndexOption}
        public SqlScriptStatisticsIncrementalIndexOption(IServiceProvider context,SqlStatisticsIncrementalIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }