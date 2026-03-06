using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptStatement<T> : SqlScriptCodeObject<T>,ISqlScriptStatement
        where T : SqlStatement
        {
        [UsedImplicitly][Field] public String StatementPhrase { get; }

        #region ctor{IServiceProvider,T}
        protected SqlScriptStatement(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }