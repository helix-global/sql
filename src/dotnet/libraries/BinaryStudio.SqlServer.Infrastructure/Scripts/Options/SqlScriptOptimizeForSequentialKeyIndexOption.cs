using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlOptimizeForSequentialKeyIndexOption))]
    internal sealed class SqlScriptOptimizeForSequentialKeyIndexOption : SqlScriptIndexOption<SqlOptimizeForSequentialKeyIndexOption>
        {
        public SqlOnOffValue OnOffValue { get { return Source.OnOffValue; }}

        #region ctor{IServiceProvider,SqlOptimizeForSequentialKeyIndexOption}
        public SqlScriptOptimizeForSequentialKeyIndexOption(IServiceProvider context,SqlOptimizeForSequentialKeyIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }