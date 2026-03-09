using JetBrains.Annotations;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using System;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptDomIndexOption<T> : SqlScriptDomObject<T>,ISqlScriptIndexOption
        where T: IndexOption
        {
        [UsedImplicitly][Field] public IndexOptionKind OptionKind { get; }

        #region ctor{IServiceProvider,T}
        protected SqlScriptDomIndexOption(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }