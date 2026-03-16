using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlTableHint))]
    internal sealed class SqlScriptTableHint : SqlScriptHint<SqlTableHint>
        {
        public SqlTableHintType Type { get { return Source.Type; }}

        #region ctor{IServiceProvider,SqlTableHint}
        public SqlScriptTableHint(IServiceProvider context,SqlTableHint source)
            : base(context,source)
            {
            }
        #endregion
        }
    }