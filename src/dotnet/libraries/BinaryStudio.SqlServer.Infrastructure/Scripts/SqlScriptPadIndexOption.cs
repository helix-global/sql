using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlPadIndexOption))]
    internal sealed class SqlScriptPadIndexOption : SqlScriptIndexOption<SqlPadIndexOption>
        {
        public SqlOnOffValue OnOffValue { get { return Source.OnOffValue; }}

        #region ctor{IServiceProvider,SqlPadIndexOption}
        public SqlScriptPadIndexOption(IServiceProvider context,SqlPadIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }