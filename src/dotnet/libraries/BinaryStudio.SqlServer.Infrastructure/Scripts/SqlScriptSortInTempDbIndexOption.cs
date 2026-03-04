using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptSortInTempDbIndexOption : SqlScriptIndexOption<SqlSortInTempDbIndexOption>
        {
        public SqlOnOffValue OnOffValue { get { return Source.OnOffValue; }}

        #region ctor{IServiceProvider,SqlSortInTempDbIndexOption}
        public SqlScriptSortInTempDbIndexOption(IServiceProvider context,SqlSortInTempDbIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }