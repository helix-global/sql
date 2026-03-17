using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlOnlineIndexOption))]
    internal sealed class SqlScriptOnlineIndexOption : SqlScriptOnOffIndexOption<SqlOnlineIndexOption>
        {
        public override SqlIndexOptionType Type { get { return SqlIndexOptionType.Online; }}

        #region ctor{IServiceProvider,SqlOnlineIndexOption}
        public SqlScriptOnlineIndexOption(IServiceProvider context,SqlOnlineIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }