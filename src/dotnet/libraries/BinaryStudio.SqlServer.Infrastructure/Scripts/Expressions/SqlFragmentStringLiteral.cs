using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(StringLiteral))]
    internal sealed class SqlFragmentStringLiteral : SqlFragmentLiteral<StringLiteral>
        {
        #region ctor{IServiceProvider,StringLiteral}
        public SqlFragmentStringLiteral(IServiceProvider context,StringLiteral source)
            : base(context,source)
            {
            }
        #endregion
        }
    }