using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlIgnoreDupKeyIndexOption))]
    internal sealed class SqlScriptIgnoreDupKeyIndexOption : SqlScriptIndexOption<SqlIgnoreDupKeyIndexOption>
        {
        public SqlOnOffValue OnOffValue {get{ return Source.OnOffValue; }}

        #region ctor{IServiceProvider,SqlIgnoreDupKeyIndexOption}
        public SqlScriptIgnoreDupKeyIndexOption(IServiceProvider context,SqlIgnoreDupKeyIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }