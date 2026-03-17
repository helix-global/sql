using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlResumableIndexOption))]
    internal sealed class SqlScriptResumableIndexOption : SqlScriptOnOffIndexOption<SqlResumableIndexOption>
        {
        public override SqlIndexOptionType Type { get { return SqlIndexOptionType.Resumable; }}

        #region ctor{IServiceProvider,SqlResumableIndexOption}
        public SqlScriptResumableIndexOption(IServiceProvider context,SqlResumableIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }